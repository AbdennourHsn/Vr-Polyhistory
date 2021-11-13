using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class PhysicsButton : MonoBehaviour
{
    [SerializeField] private float threshold = 0.1f;
    [SerializeField] private float deadZone= 0.025f;
    [SerializeField] UnityEvent OnPresed;
    public bool isPresed;
    Vector3 startPos;
    ConfigurableJoint join;

    // Start is called before the first frame update
    void Start()
    {
        startPos = this.transform.localPosition;
        join = this.GetComponent<ConfigurableJoint>();
    }

    // Update is called once per frame
    void Update()
    {

        if (!isPresed && GetValue() + threshold >= 1)  Pressed();
        if (isPresed && GetValue() - threshold <= 0) Relessed();
    }

    public void Pressed()
    {
        isPresed = true;
        OnPresed.Invoke();
        print("ha anaaaaaaaaa");
    }
    public void Relessed()
    {
        isPresed = false;
        OnPresed.Invoke();
    }
    private float GetValue()
    {
        var value = Vector3.Distance(startPos, transform.localPosition)/join.linearLimit.limit ;
        if (Mathf.Abs(value) < deadZone) value = 0;
        return Mathf.Clamp(value ,-1,1);
    }
}