using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LookForWard : MonoBehaviour
{
    public Camera camera;
    


    // Update is called once per frame
    void Update()
    {
        Vector3 target = new Vector3(camera.transform.position.x, transform.position.y , camera.transform.position.z);
        this.transform.LookAt(target);
    }
    IEnumerator MoveUpAndDown()
    {
        LeanTween.moveY(gameObject, this.transform.position.y - 0.4f, 1.2f);
        
        yield return new WaitForSeconds(1.2f);
        LeanTween.moveY(gameObject, this.transform.position.y+0.4f, 1.2f);
        yield return new WaitForSeconds(1.2f);
        StartCoroutine(MoveUpAndDown());
    }

}
